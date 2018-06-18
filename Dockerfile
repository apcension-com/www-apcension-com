From jekyll/jekyll

COPY Gemfile /tmp/

WORKDIR /tmp

RUN gem install bundler

RUN bundle install
