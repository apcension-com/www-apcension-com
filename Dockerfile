From jekyll/jekyll@sha256:6db89319cd92f0188fde957cfbb346085a8c9615249247b8dede4d542827265b

COPY Gemfile /root/

WORKDIR /root

RUN gem install bundler

 RUN bundle install
