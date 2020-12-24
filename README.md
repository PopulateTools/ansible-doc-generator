# ansible-doc-generator

CLI for documenting Ansible roles into Markdown files.

Documentation is generated from _magic_ comments declared in the tasks file of a role. These are the comments accepted:

# @metatitle

# @title

# @comment

# @input

# @output

## Localization

`@metatitle`, `@title` and `@comment` support localization, by adding at the end of the label the locale code, i.e.:

```
# @title_es Instalar Ruby
# @title_en Install Ruby
# @comment_es Este rol instala Ruby utilizando Rbenv
# @comment_en This role installs Ruby using Rbenv
```

When calling the generation, you'll need to add a second parameter with the locale you want to
generate:

```
$ ansible-doc-generator ~/ansible/playbooks/ruby.yml es # to generate Spanish documentation
```

## Installation

```
$ gem install ansible-doc-generator
```

## TODO

- [ ] better error reporting
- [ ] support includes
- [ ] deal with conditions


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/PopulateTools/ansible-doc-generator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Authors

This is a project developed by [Populate](https://populate.tools) team to document our Ansible roles and provide a great documentation to our customers.
