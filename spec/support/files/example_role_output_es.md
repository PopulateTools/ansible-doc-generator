### Añadir el repositorio para fullstaq ruby en yum

```
yum-config-manager --add-repo https://yum.fullstaqruby.org/centos-7/$basearch
```

### Instalar el paquete fullstaq ruby

```
yum install -y fullstaq-ruby-common
```

### Instalar las versiones de ruby

```
yum install -y {{ ruby_versions }}
```

### Instalar el plugin de rbenv `rbenv-vars`

Este plugin permite a las aplicaciones cargar las variables de entorno definidas en el fichero `.rbenv-vars`

```
git clone https://github.com/rbenv/rbenv-vars.git /usr/lib/rbenv/plugins/rbenv-vars
```

### Activar rbenv

Añadir una entrada en /etc/bashrc para activar rbenv

```
eval "$(rbenv init -)"
```

### Activar plugin rbenv-vars
