# coding: utf-8
Gem::Specification.new do |s|
  s.name        = 'redmine_apijs'
  s.version     = 'x.y.z'
  s.summary     = 'Redmine Apijs plugin'
  s.description = 'Integrate the apijs JavaScript library into Redmine. Provides a gallery for image and video attachments. Gem for Redmine 3.0+ (tested with 3.0..5.0), for Redmine 4.1+ read https://redmine.org/issues/31110#note-8'
  s.homepage    = 'https://github.com/luigifab/redmine-apijs'
  s.license     = 'GPL-2.0-or-later'
  s.authors     = ['Fabrice Creuzot']
  s.email       = 'code@luigifab.fr'
  s.metadata    = {
    'bug_tracker_uri'   => 'https://github.com/luigifab/redmine-apijs/issues',
    'documentation_uri' => 'https://www.luigifab.fr/redmine/apijs',
    'homepage_uri'      => 'https://www.redmine.org/plugins/apijs'
  }
  s.required_ruby_version = '>= 1.9'
  s.files = %w[
    app/controllers/apijs_controller.rb
    app/views/application/_browser.html.erb
    app/views/attachments/_links.html.erb
    app/views/settings/_apijs.html.erb
    assets/fonts/apijs/config.json
    assets/fonts/apijs/fontello.woff
    assets/fonts/apijs/fontello.woff2
    assets/images/apijs/player-black-200.png
    assets/images/apijs/player-black-400.png
    assets/images/apijs/player-white-200.png
    assets/images/apijs/player-white-400.png
    assets/images/apijs/tv.gif
    assets/javascripts/apijs-redmine.js
    assets/javascripts/apijs-redmine.min.js
    assets/javascripts/apijs-redmine.min.js.map
    assets/javascripts/apijs.min.js
    assets/javascripts/apijs.min.js.map
    assets/stylesheets/apijs-print.min.css
    assets/stylesheets/apijs-print.min.css.map
    assets/stylesheets/apijs-redmine-rtl.min.css
    assets/stylesheets/apijs-redmine-rtl.min.css.map
    assets/stylesheets/apijs-redmine.css
    assets/stylesheets/apijs-redmine.min.css
    assets/stylesheets/apijs-redmine.min.css.map
    assets/stylesheets/apijs-screen-rtl.min.css
    assets/stylesheets/apijs-screen-rtl.min.css.map
    assets/stylesheets/apijs-screen.min.css
    assets/stylesheets/apijs-screen.min.css.map
    config/locales/cs.yml
    config/locales/de.yml
    config/locales/el.yml
    config/locales/en.yml
    config/locales/es.yml
    config/locales/fr.yml
    config/locales/hu.yml
    config/locales/it.yml
    config/locales/ja.yml
    config/locales/nl.yml
    config/locales/pl.yml
    config/locales/pt-BR.yml
    config/locales/pt.yml
    config/locales/ro.yml
    config/locales/ru.yml
    config/locales/sk.yml
    config/locales/tr.yml
    config/locales/uk.yml
    config/locales/zh.yml
    config/routes.rb
    Gemfile
    init.rb
    lib/apijs_attachment.rb
    lib/apijs_files.rb
    lib/image.py
    lib/redmine_apijs.rb
    lib/useragentparser.rb
    LICENSE
    README
    redmine_apijs.gemspec
  ]
end