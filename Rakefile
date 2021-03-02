# frozen_string_literal: true

require_relative './lib/search_index'

namespace :guides do
  desc 'Generate guides (for authors), use ONLY=foo to process just "foo.md"'
  task generate: "generate:html"

  # Guides are written in UTF-8, but the environment may be configured for some
  # other locale, these tasks are responsible for ensuring the default external
  # encoding is UTF-8.
  #
  # Real use cases: Generation was reported to fail on a machine configured with
  # GBK (Chinese). The docs server once got misconfigured somehow and had "C",
  # which broke generation too.
  task :encoding do
    %w(LANG LANGUAGE LC_ALL).each do |env_var|
      ENV[env_var] = "en_US.UTF-8"
    end
  end

  namespace :generate do
    desc "Generate HTML guides"
    task :html do
      ENV["WARNINGS"] = "1" # authors can't disable this
      ENV["RAILS_VERSION"] = "v6.1.3"
      ENV["GUIDES_LANGUAGE"] = "pt-BR"
      system 'git apply rails.patch'
      system 'cp -r ./pt-BR rails/guides/source'
      ruby "-Eutf-8:utf-8", "rails/guides/rails_guides.rb"
      system 'rm -rf output'
      system 'mv rails/guides/output output'
      system 'rm -rf rails/guides/source/pt-BR'
      RailsGuides::SearchIndex.new.generate
    end

    desc "Generate .mobi file. The kindlegen executable must be in your PATH. You can get it for free from http://www.amazon.com/gp/feature.html?docId=1000765211"
    task :kindle do
      require "kindlerb"
      unless Kindlerb.kindlegen_available?
        abort "Please run `setupkindlerb` to install kindlegen"
      end
      unless /convert/.match?(`convert`)
        abort "Please install ImageMagick"
      end
      ENV["KINDLE"] = "1"
      ENV["RAILS_VERSION"] = "v6.1.3"
      ENV["GUIDES_LANGUAGE"] = "pt-BR"
      system('git apply rails.patch')
      # Rake::Task["guides:generate:html"].invoke
      system 'cp -r ./pt-BR rails/guides/source'
      ruby "-Eutf-8:utf-8", "rails/guides/rails_guides.rb"
      system 'cp -r rails/guides/output output'
      system 'rm -rf rails/guides/source/pt-BR && rm -rf rails/guides/output'
    end
  end

  # Validate guides -------------------------------------------------------------------------
  desc 'Validate guides, use ONLY=foo to process just "foo.html"'
  task validate: :encoding do
    ruby "rails/guides/w3c_validator.rb"
  end

  desc "Show help"
  task :help do
    puts <<HELP

Guides are taken from the source directory, and the result goes into the
output directory. Assets are stored under files, and copied to output/files as
part of the generation process.

You can generate HTML, Kindle or both formats using the `guides:generate` task.

All of these processes are handled via rake tasks, here's a full list of them:

#{%x[rake -T]}
Some arguments may be passed via environment variables:

  RAILS_VERSION=tag
    If guides are being generated for a specific Rails version set the Git tag
    here, otherwise the current SHA1 is going to be used to generate edge guides.

  ALL=1
    Force generation of all guides.

  ONLY=name
    Useful if you want to generate only one or a set of guides.

    Generate only association_basics.html:
      ONLY=assoc

    Separate many using commas:
      ONLY=assoc,migrations

  GUIDES_LANGUAGE
    Use it when you want to generate translated guides in
    source/<GUIDES_LANGUAGE> folder (such as source/es)

Examples:
  $ rake guides:generate ALL=1 RAILS_VERSION=v5.1.0
  $ rake guides:generate ONLY=migrations
  $ rake guides:generate:kindle
  $ rake guides:generate GUIDES_LANGUAGE=es
HELP
  end
end

task default: "guides:help"

namespace :assets do
  task :precompile do
    system('rake guides:generate:html')
    system('cp $(find output/pt-BR -name "*.html") site')
  end
end
