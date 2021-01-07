require_relative "playbook_helpers"
require_relative "doc_generator/playbook_introduction_extractor"
require_relative "doc_generator/role_doc_extractor"

module AnsibleDocGenerator
  class DocGenerator
    include PlaybookHelpers

    attr_reader :playbook_path, :lang
    attr_accessor :md_output

    def initialize playbook_path, lang
      @playbook_path = playbook_path
      @lang = lang
      @md_output = []
    end

    def call
      parse_introduction
      parse_roles
      write_readme
    end

    private

    def parse_introduction
      md_output << PlaybookIntroductionExtractor.new(playbook_path, lang).call
    end

    def parse_roles
      paths.each do |path|
        yml_path = tasks_yml_path_for_role(path)
        maybe_generate_doc_for_role yml_path
      end
    end

    def write_readme
      doc_path = File.join(project_folder, 'docs', "installation_#{lang}.md")

      delete_if_exists(doc_path)
      FileUtils.mkdir_p(File.dirname(doc_path))
      File.open(doc_path, 'w'){|file| file.write(clean_md_output) }

      puts "> Installation guide saved in #{doc_path}"
    end

    def maybe_generate_doc_for_role yml_path
      if File.exists?(yml_path)
        puts "+ Generating doc for: #{yml_path}"
        generate_doc_for_role yml_path
      else
        puts "- main.yml not found in path #{yml_path}"
      end
    end

    def generate_doc_for_role yml_path
      md_output << RoleDocExtractor.new(yml_path, lang).call
    end

    def clean_md_output
      md_output.reject{|line| line.strip == '' || line.nil? }.join("\n\n")
    end

    def tasks_yml_path_for_role path
      File.join(project_folder, path, 'tasks', 'main.yml')
    end

  end
end
