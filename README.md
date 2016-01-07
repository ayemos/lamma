# Lamma
[![Gem Version](https://badge.fury.io/rb/lamma.svg)](https://badge.fury.io/rb/lamma)
[![Code Climate](https://codeclimate.com/github/ayemos/lamma/badges/gpa.svg)](https://codeclimate.com/github/ayemos/lamma)
[![Test Coverage](https://codeclimate.com/github/ayemos/lamma/badges/coverage.svg)](https://codeclimate.com/github/ayemos/lamma/coverage)
[![Issue Count](https://codeclimate.com/github/ayemos/lamma/badges/issue_count.svg)](https://codeclimate.com/github/ayemos/lamma)

It will help [Amazon Lambda](http://aws.amazon.com/lambda/) developer to, 
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

## Usage & Basic Workflow

### Create new Lambda Function
```
lamma create my_function --runtime 'python2.7'
```
![create]()

### Deploy current code to Remote

You have to be in a directory created by 'create' command with 'lamma.conf' file.

Make some change on nodejs/python2.7 function and

```
lamma deploy production(or development)
```
![create]()
![console]()

### Rollback last deploy

```
lamma rollback production(or development)
```
![before]()
![after]()

### Recommended setting
It is recommended to connect your lambda with an event source via PROD/DEV version aliases, 
so that you can keep the mapping before/after the deployment/rollback.
([see also](https://docs.aws.amazon.com/lambda/latest/dg/versioning-aliases.html))

End-to-end functionalities for 
- Managing event-source-mappings,
- Creating IAM roles
 
will be supported in future release.

