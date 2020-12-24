### Add fullstaq ruby repository for yum

```
yum-config-manager --add-repo https://yum.fullstaqruby.org/centos-7/$basearch
```

### Install fullstaq ruby package

```
yum install -y fullstaq-ruby-common
```

### Install ruby versions

```
yum install -y {{ ruby_versions }}
```

### Install `rbenv-vars` plugin

This plugin allows applications to load environment variables from a file called `.rbenv-vars` automatically

```
git clone https://github.com/rbenv/rbenv-vars.git /usr/lib/rbenv/plugins/rbenv-vars
```

### Activate rbenv

Add a line in /etc/bashrc to activate rbenv

```
eval "$(rbenv init -)"
```

### Activate rbenv-vars plugin

```
/etc/bashrc
```
