require 'yaml'

module AnsibleDocGenerator
  module PlaybookHelpers

    private

    def delete_if_exists path
      FileUtils.remove_entry(path, true)
    end

    def paths
      @paths ||= roles.map{|role| role['role'] }
    end

    def roles
      playbook['roles']
    end

    def project_folder
      @project_folder ||= File.dirname(playbook_path)
    end

    def playbook
      @playbook ||= YAML.load_file(playbook_path).first
    end
  end
end
