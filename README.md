# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

rails new aws-example --database=mysql --skip-keeps --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-active-storage --skip-puma --skip-action-cable --skip-sprockets --skip-spring --skip-turbolinks --skip-test --skip-bootsnap


# https://medium.com/quick-code/setting-up-godaddy-domain-and-aws-route-53-with-elastic-beanstalk-within-15-minutes-a0276ff4ea6e
# https://console.aws.amazon.com/route53/home?region=us-west-2#resource-record-sets:ZVCQQ5F2L2KB2d

# https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/configuring-https-httpredirect.html

BEANSTALK TERRAFORM LINKS
* https://medium.com/@jackmahoneynz/deploying-applications-to-elasticbeanstalk-with-terraform-6c0694558ccf
  Simple overview using the cloudposse module, using zip + environment + version, and manually deploying the version at the end
* https://www.tastycidr.net/aws-codepipeline-ci-the-amazon-way/
  Code pipeline + build setup with golang
* https://stephenmann.io/post/continuous-delivery-with-beanstalk-codepipeline-and-terraform/
  Indepth article about setting this up with nodejs

