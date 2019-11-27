# Reviews

[![CircleCI](https://circleci.com/gh/solidusio-contrib/solidus_reviews.svg?style=svg)](https://circleci.com/gh/solidusio-contrib/solidus_reviews)

Straightforward review/rating functionality, updated for [Solidus](https://solidus.io).

While the gem's name has changed, the module namespace and commands are still `spree` for now.

## Installation

Add the following to your `Gemfile` to install from git:

```ruby
gem 'solidus_reviews', github: 'solidusio-contrib/solidus_reviews'
```
Now bundle up with:

```console
$ bundle
```

Next, run the rake task that copies the necessary migrations and assets to your project:

```console
$ rails g solidus_reviews:install
```


And finish with a migrate:

```console
$ rake db:migrate
```

Now you should be able to boot up your server with:

```console
$ rails s
```

That's all!

## Usage

The `Spree::ReviewsController` controller provides all the CRUD functionality for product reviews.

The `Spree::FeedbackReviewsController` allows user to express their feedback on a specific review.
You can think of these as meta-reviews (e.g. the classic "Was this useful?" modal).

You can approve, edit and delete reviews and feedback reviews from the backend.

## Factories

If you want factories for our models available in your application, simply require our factories in
your `spec_helper.rb`:

```ruby
require 'solidus_reviews/factories'
```

## Testing

Just run the following to automatically build a dummy app if necessary and run the tests:

```shell
$ bundle exec rake
```

## Contributing

If you want to contribute, have a look at out [contributing guidelines](https://github.com/solidusio-contrib/solidus_reviews/blob/master/CONTRIBUTING.md).

## License

Copyright (c) 2009-2019 [Solidus](https://github.com/solidusio) and [contributors](https://github.com/solidusio-contrib/solidus_reviews/graphs/contributors),
released under the [New BSD License](https://github.com/solidusio-contrib/solidus_reviews/blob/master/LICENSE.md).
