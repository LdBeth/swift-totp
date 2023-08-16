# TOTP

This is a command line One-Time Password generator implements RFC 6238.

_This project is developed without using Xcode, only Command Line Tools
should be required to build the program. Why? Because Xcode sucks._

```text
$ totp -a <account> <secrete> # add acount
$ totp -d <account> # delete account
$ totp  # list accounts
$ totp <account> # generate password
```

Passwords are stored in macOS keychain so you can manage it through Keychain.app.

Note that secrete is assumed in base 32 format.

## GPLv3 License

Copyright (C) 2023 by LdBeth

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
