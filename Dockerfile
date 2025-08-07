FROM ruby:3.4.5

RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

RUN npm install playwright
RUN npx playwright install chromium --with-deps

COPY Gemfile Gemfile.lock ./
ENV BUNDLE_FROZEN=true
RUN gem install bundler && bundle install

COPY . ./
ENTRYPOINT [ "ruby", "./main.rb" ]
