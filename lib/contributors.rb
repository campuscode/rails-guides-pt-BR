# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'pry-byebug'

url = 'https://api.github.com/search/issues?q=repo:campuscode/rails-guides-pt-BR+is:pr+is:merged'

connection = Faraday.new(url: url) do |faraday|
  faraday.headers['Accept'] = 'application/vnd.github.cloak-preview'
  faraday.headers['Authorization'] = "token #{ENV['GITHUB_PERSONAL']}"
  faraday.response :json, parser_options: { symbolize_names: true },
                          content_type: /\bjson$/
  faraday.adapter :net_http
end

grouped_response = (1..10).inject([]) do |accu, i|
  response = connection.get do |req|
    req.params['page'] = i
    req.params['per_page'] = 100
  end
  break accu if response.body.empty?

  accu.push(*response.body[:items])
end

binding.pry

contributors_data = grouped_response
                      .group_by! { _1.dig(:user, :login) }
                      .map! { [_1, _2.first.dig(:user, :html_url), _2.size] }
                      .sort_by(&:last)
                      .reverse

md = <<~HEREDOC
      | | Usuário | N.º de Contribuições
      |:------------- |:-------------|:-----|
    HEREDOC

contributors_data.map!.with_index(1) do |item, index|
  md << "|#{index}|[#{item[0]}](#{item[1]}|[#{item[2]}](https://github.com/campuscode/rails-guides-pt-BR/pull?q=is:pr+is:merged+author:#{item[0]}))"
end

# |#1|[HenriqueMorato](https://github.com/HenriqueMorato)|[6](https://github.com/campuscode/rails-guides-pt-BR/pulls?q=is%3Apr+is%3Aclosed+author%3AHenriqueMorato)
