FROM ruby:buster

WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock ./
ENV BUNDLE_FROZEN=true
RUN gem install bundler && bundle install

COPY . ./
CMD ["ruby", "./main.rb", "update"]
