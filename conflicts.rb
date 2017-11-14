$VERBOSE = nil
require 'json'
require 'date'

CMD_LINE_ARGS = Hash[ ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/) ]
DEFAULT_RECENCY = 2 # Days

def get_changed_files(change_json)
  current_ps_data = change_json['currentPatchSet']

  if current_ps_data
  changed_file_data = current_ps_data['files']
  changed_files = changed_file_data.map{|file_data| file_data['file'] }
  changed_files.delete_if {|file| file == '/COMMIT_MSG'}
  changed_files
  else
    []
  end
end

current_change_id = `git log -1 | grep Change-Id | sed -n -e 's/^.*Change-Id: //p'`
change_details_with_stats = `ssh -p 29418 gerrit.rfiserve.net gerrit query --format=JSON --files --current-patch-set change:#{current_change_id}`

change_details = StringIO.new(change_details_with_stats).lines.first
current_change_json = JSON.parse(change_details)
current_changed_files = get_changed_files(current_change_json)

open_changes = StringIO.new `ssh -p 29418 gerrit.rfiserve.net gerrit query --format=JSON --files --current-patch-set status:open project:ui/orion`

open_changes.each_line do |change_details|
  change_json = JSON.parse(change_details)

  next if change_json['type'] == 'stats'

  owner_full_name = change_json['owner']['name']
  next if current_change_json['owner']['name'] == owner_full_name

  is_recent = DateTime.strptime(change_json['lastUpdated'].to_s,'%s') >
      DateTime.now - (CMD_LINE_ARGS['recency'] || DEFAULT_RECENCY).to_i

  # the changes are returned sorted DESC by lastUpdated so it's safe to early-return here
  break unless is_recent

  common_changed_files = current_changed_files & get_changed_files(change_json)

  if common_changed_files.length > 0
    cmt_msg = change_json['commitMessage'].split("\n").first

    puts "You and #{owner_full_name} are both modifying the files: #{common_changed_files.join(', ')}"
    #puts "See #{owner_full_name.split(' ').first}'s commit \"#{cmt_msg}\" with change-id = #{change_json['id']}"
    puts "See #{owner_full_name.split(' ').first}'s commit \"#{cmt_msg}\" at #{change_json['url']}"
    puts
  end
end

