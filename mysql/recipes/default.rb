include_recipe "mysql"

node['mysql'].each do |instance|
    name = instance[0]
    log "Setting instance #{name}"

    # Setup backup directory
    directory "datadir#{name}" do
	path "#{node['mysql'][name]['backup']}"
	owner "root"
	group "root"
	mode "0770"
	action :create
    end

    # Backup execution
    bash "backup-on-demand#{name}" do
	user "root"
	cwd "/tmp"
	action :nothing
	code <<-EOH
	for DB in $(mysql -e 'show databases' -s --skip-column-names); do
        mysqldump $DB > "/tmp/backup/$DB.sql";
    done
	EOH
    end

    # Create cronjob
    cron "schedule-for-backup#{name}" do
    action :create
    minute '12'
    hour '1'
    weekday '7'
    user 'root'
    command '/opt/backup.sh >> /var/log/backup.log 2&>1'
    end

    # Create a backup script
    cookbook_file "backup-script#{name}" do
        path "/opt/backup.sh"
        source "backup.sh"
        owner "root"
        group "root"
        mode "0754"
        action :create
    end

end
