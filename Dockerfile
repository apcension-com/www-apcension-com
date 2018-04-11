From jekyll/jekyll

COPY Gemfile /root/

WORKDIR /root

RUN gem install bundler

 RUN bundle install
