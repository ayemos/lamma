# Lamma
[![Gem Version](https://badge.fury.io/rb/lamma.svg)](https://badge.fury.io/rb/lamma)
[![Code Climate](https://codeclimate.com/github/ayemos/lamma/badges/gpa.svg)](https://codeclimate.com/github/ayemos/lamma)
[![Test Coverage](https://codeclimate.com/github/ayemos/lamma/badges/coverage.svg)](https://codeclimate.com/github/ayemos/lamma/coverage)
[![Issue Count](https://codeclimate.com/github/ayemos/lamma/badges/issue_count.svg)](https://codeclimate.com/github/ayemos/lamma)

It will help [AWS Lambda](http://aws.amazon.com/lambda/) developers to,
- Create new function,
- Deploy current code,
- and to Rollback last deployment.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lamma'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lamma

## Configuration
The gem uses [aws-sdk-ruby](http://aws.amazon.com/sdk-for-ruby/) to get an access to AWS api-es.

``` AWS_ACCESS_KEY_ID ``` and ``` AWS_SECRET_ACCESS_KEY ``` have to be set within your environment.

```
export AWS_ACCESS_KEY_ID = [YOUR_AWS_ACCESS_KEY_ID]
export AWS_SECRET_ACCESS_KEY = [YOUR_AWS_SECRET_ACCESS_KEY]
```

# Todo
- [x] Support Automatic IAM Role initialization
- [ ] Support dead letter queue configuration
- [x] Support environment variables
- [x] Support KMS encripted variable configuration
- [ ] Support VPC configuration
- [ ] Prepare init templates
  - [x] python2.7
  - [ ] node4.3
  - [ ] node4.3 edge
  - [ ] C#
  - [ ] Java8
