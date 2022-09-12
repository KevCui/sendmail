# sendmail

> Send anonymous email to any recipients from your terminal

## Table of Contents

- [Dependency](#dependency)
- [Usage](#usage)
  - [Examples](#examples)
- [Limitation](#limitation)
- [Similar projects](#similar-projects)

## Dependency

- [cURL](https://curl.haxx.se/download.html)

- [viu](https://github.com/atanunq/viu)

## Usage

```
Usage:
  ./sendmail.sh -t <to_address> [-s <subject>|-m <message>]

Options:
  -t               required, recipient mail address
  -s               optional, subject
  -m               optional, message
  -h | --help      display this help message
```

### Examples

- Send an email to `test@example.com` with random subject and message:

```bash
$ ./sendmail.sh -t test@example.com
Enter captcha letters:
...
```

- Send an email to `test@example.com` with specific subject and message:

```bash
$ ./sendmail.sh -t test@example.com -s 'this is the subject' -m 'message here'
Enter captcha letters:
...
```

:warning: Be aware that the sender address is fixed as `mailer@app.tempr.email`.

## Limitation

- Since [Tempr.email](https://tempr.email/) uses 5-letter captcha to prevent the abuse of their mail sending service, manually entering 5-letter captcha text is required before sending each email. The captcha letters will be shown in the terminal by `viu`. It's not perfect for hands-free, but so far, there isn't a good solution to automate captcha solving process yet.

- There is a request limit from [Tempr.email](https://tempr.email/): **max. 15 emails per hour per IP address**. (It won't be a problem if you know how to use Tor.)

## Similar projects

Want more temp mail service? Check out:

- [1secmail](https://github.com/KevCui/1secmail)

- [getnada](https://github.com/KevCui/getnada)

- [tempmail](https://github.com/KevCui/tempmail)

You may like them!

---

<a href="https://www.buymeacoffee.com/kevcui" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-orange.png" alt="Buy Me A Coffee" height="60px" width="217px"></a>