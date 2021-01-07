# ansible-doc-generator

CLI for documenting Ansible roles into Markdown files.

Documentation is generated from _magic_ comments declared in the tasks file of a role, where everycomment should be put before the declaration of the task.

These are the types of comments accepted:

- `@metatitle` defines a high level title (equivalent to h2). It's expected to be just one metatitle per role
- `@title` defines the title of the role or the title of the step (it's flexible)
- `@comment` completes the information provided by the title. This comment allows multiple lines and multiple instances
- `@input` defines the command or action executed by the task. Produces a block of code. This comment is also multiline
- `@output` defines the result of the execution. Produces a block of code

Here's an example of role that uses most of the comments and variable interpolation (see [explanation below](#variable-interpolation)):

```yaml
---
# @metatitle Install Postgresql

# @input wget --quiet -O - #{apt_key>url} | sudo apt-key add -
- name: Add APT key
  become: true
  apt_key:
    url: "https://www.postgresql.org/media/keys/ACCC4CF8.asc"
    state: present

# @title Add repository
# @input sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
- name: Add APT postgres repository
  become: true
  apt_repository:
    repo: deb http://apt.postgresql.org/pub/repos/apt/ {{ansible_distribution_release}}-pgdg main
    state: present
    filename: 'pgdg.list'

# @title Install #{apt>pkg} packages
# @input apt install -y #{apt>pkg | join: ' '}
- name: Install Postgres
  become: true
  apt:
    pkg: ['postgresql-12', 'postgresql-server-dev-12', 'postgresql-contrib-12']
    state: present
    update_cache: yes

# @title Install PostGis 3
# @input apt install -y #{apt>pkg | join: ' '}
- name: Install PostGis
  become: true
  apt:
    pkg: postgresql-12-postgis-3
    state: present
```

## Other features

### Localization

`@metatitle`, `@title` and `@comment` support localization, by adding at the end of the label the locale code, i.e.:

```
# @title_es Instalar Ruby
# @title_en Install Ruby
# @comment_es Este rol instala Ruby utilizando Rbenv.
# @comment_en This role installs Ruby using Rbenv
```

To get the Spanish documentation you should run:

```
$ ansible-doc-generator -p ~/ansible/playbooks/ruby.yml -l es
```

### Variable interpolation

Comments allow variable interpolation with the syntax `#{var}`. If the variable is defined in a sub-level it can be reached using the `>` operator, i.e. `#{apt>pkg}`.

Example: 

```yaml 
# @title #{name}
# @input apt install -y #{apt>pkg | join: ' '}
- name: Install Postgres
  apt:
    pkg: ['postgresql-12', 'postgresql-server-dev-12', 'postgresql-contrib-12']
    state: present
    update_cache: yes
```

Inline syntax is also supported:

```yaml 
# @input systemctl start #{service>name}
- name: Enable and start monit
  become: true
  service: name=monit enabled=yes state=started
```

### File interpolation

You can print the output of a file located within `files` or `template` of the same role with the syntax `f{filename.txt}`.

For instance, given the following task inside the role `nginx/tasks/main.yml`, it will look for the file in `nginx/files/nginx.monit` and `nginx/templates/nginx.monit` and put its content.

```yaml
# @input f{nginx.monit}
- name: Copy the nginx monit service files
  copy:
    src: nginx.monit
    dest: /etc/monit.d/nginx.monit
```

## Installation

```
$ gem install ansible-doc-generator
```

## Usage

```bash
$ ansible-doc-generator -p ~/ansible/playbooks/ruby.yml -l es
```

- `-p` (mandatory) with the path of the ansible playbook.
- `-l` (optional) with the language you want to generate the guide with. Default is `en`.

## TODO

- [ ] Provide an example of documented repository
- [ ] better error reporting
- [ ] support includes
- [ ] deal with conditions

For a more complete list review the repository issues.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/PopulateTools/ansible-doc-generator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Authors

This is a project developed by [Populate](https://populate.tools) team to document our Ansible roles and provide a great documentation to our customers.
