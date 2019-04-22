#!/usr/bin/perl -w

use Mojolicious::Lite;

# Создаем массив с тестовыми данными

# В нашем примере при создании/изменении используется
# только один параметр: URI видео файла для скачивания
my $downloads = [];

foreach my $id (0..10) {
  $downloads->[$id] =
    { 'id'   => $id,
      'uri'  => "http://site.com/download_$id",
      'name' => "Video $id",
      'size' => (int(rand(10000)) + 1) * 1024
    };
}
 

# Непосредственное описание методов веб-сервиса

# Создание (create)
post '/downloads/' => sub {
  my $self   = shift;

  # Мы получаем от Rails все параметры в JSON
  # Поэтому, их надо распарсить
  my $params =  Mojo::JSON->decode($self->req->body)->{'download'};

  # При создании в качестве уникального id выступает
  # последний индекс нашего тестового массива
  my $id     = $#{ $downloads } + 1;
  my $uri    = $params->{'uri'}  || 'http://localhost/video.mp4';
  my $name   = $params->{'name'} || "Video $id";
  my $size   = $params->{'size'} || (int(rand(10000)) + 1) * 1024;

  $downloads->[$id] =
    { 'id'   => $id,
      'uri'  => $uri,
      'name' => $name,
      'size' => $size
    };

  # Отправляем в качестве ответа созданный объект
  $self->render_json($downloads->[$id]);
};

# Список всех объектов (index)
get '/downloads' => sub {
  my $self = shift;
  $self->render_json($downloads);
};

# Поиск и получение информации объекта (find/show)
get '/downloads/:id' => sub {
  my $self = shift;
  my $id   = $self->param('id');

  if (!exists($downloads->[$id])) {
    
    # Если нет такого объекта - 404
    $self->render_not_found;
  } else {

    # Иначе - отдаем объект
    $self->render_json($downloads->[$id]);
  }
};

# Редактирование (update)
put '/downloads/:id' => sub {
  my $self   = shift;
  my $params =  Mojo::JSON->decode($self->req->body)->{'download'};

  my $id     = $self->param('id');
  my $uri    = $params->{'uri'}  || 'http://localhost/video.mp4';
  my $name   = $params->{'name'} || "Video $id";
  my $size   = $params->{'size'} || (int(rand(10000)) + 1) * 1024;

  if (!exists($downloads->[$id])) {
    $self->render_not_found;
  } else {
    $downloads->[$id] =
      { 'id'   => $id,
        'uri'  => $uri,
        'name' => $name,
        'size' => $size
      };

    $self->render_json($downloads->[$id]);
  }
};

# Удаление (delete)
del '/downloads/:id' => sub {
  my $self = shift;
  my $id   = $self->param('id');

  if (!exists($downloads->[$id])) {
    $self->render_not_found;
  } else {
    delete $downloads->[$id];

    # Посылаем HTTP 200 OK - объект успешно удален
    $self->rendered;
  }
};
  
# Пример нестандартной функции - старт загрузки
post '/downloads/:id/start' => sub {
  my $self = shift;
  my $id   = $self->param('id');

  if (!exists($downloads->[$id])) {
    $self->render_not_found;
  } else {
    $self->rendered;
  }
}; 


# Непосредственный запуск сервера
app->start;
