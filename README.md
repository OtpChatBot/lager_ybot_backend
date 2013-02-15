lager_ybot_backend
===================

lager_ybot_backend - is Ybot's backend for Basho Lager logging framework. 
It allows to receive lager error messages in your favorite messenger in real time.
It's build on top of two libraries:

  * Basho [lager](https://github.com/basho/lager) - A logging framework for Erlang/OTP
  * [Ybot](https://github.com/0xAX/Ybot) - chat robot

The principle of operation is simple: You have runned Ybot in your machine which sits in some
chat rooms. Also you have some erlang project's which logging with lager.

It supports resending error lagers messages to:

  * IRC
  * XMPP
  * 37signals campfire chat.
  * Google talk.
  * HipChat.

Configuring and usage
=======================

Just include ybot backend into your project with rebar:

```erlang
{lager_ybot_backend, 
	".*", {git, "https://github.com/0xAX/lager_ybot_backend.git", "master"}}
```

And configure lager:

```erlang
{lager, [
  {handlers, [
    {lager_ybot_backend, [
      {name, "lager_ybot_backend"},
      {level, error},
      {ybot_host, "http://localhost"},
      {ybot_port, 8080}
    ]}
  ]}
]}
```

After that it will sends error logging message to all chats are running your Ybot.

Author
========

[@0xAX](https://twitter.com/0xAX). 



