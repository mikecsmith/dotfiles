# Mike's Dotfiles

Super quick instructions on how this all works.

## Basics

- Clone the repository to your home directory.
- Create the required directories via `./create_dirs.sh`
- Set MacOS defaults via `./settings.sh`
- Configure the Dock via `./dock.sh`
- Install packages via `./install_pkgs.sh`
- Create symlinks using `./stow.sh`
- Install default programming languages and tools via `mise install`
  - `mise` is configured via `config/mise/config.toml`

## Package Management

- Packages are managed via the `packages.brewfile`
- Add a new file to the repo using `vi packages.brewfile`
- Run `./install_pkgs.sh` to install the package.
- Software languages and toolchains (except Rust which uses `rustup`) are configured via `mise`

## Mail Client Setup (aerc)

This requires a bit of setup to get working correctly.

- Clone [lieer](https://github.com/gauteh/lieer)
- Edit `lieer/remote.py` and replace `OAUTH_CLIENT_SECRET` with the following:

```python
OAUTH2_CLIENT_SECRET = {
    "client_id": "406964657835-aq8lmia8j95dhl1a2bvharmfk3t1hgqj.apps.googleusercontent.com",
    "project_id": "capable-pixel-160614",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://accounts.google.com/o/oauth2/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_secret": "kSmqreRr0qwBWJgbf5Y-PjSU",
    "redirect_uris": ["urn:ietf:wg:oauth:2.0:oob", "http://localhost"],
}
```

- This updates the `client_id` and `client_secret` values with those of Thunderbird.
- [lieer](https://github.com/gauteh/lieer) can now be built with `CFLAGS="-I$(brew --prefix)/opt/notmuch/include" pip install .`
  - Note - this adds `notmuch.h` (installed via `brew`) to the include path for the build.
- Build a `wheel` with `python setup.py sdist bdist_wheel`
- Install `lieer` globally with `pip install dist/lieer-1.6-py3-none-any.whl` (or whatever the version is)
- Now follow `notmuch` setup instructions in the `~/.mail` directory.
- Run `gmi init <your-email>` inside the `~/.mail` dir to initialize the mail directory.
- Run `gmi sync` to sync your mail.
- Create `config/aerc/accounts.conf` with the following:

```text
[GMAIL]
source        = notmuch://~/.mail
check-mail-cmd = gmi sync --path=~/.mail
check-mail-timeout = 120s
outgoing = gmi send -t -C ~/.mail
default       = INBOX
from          = Your Name <your@email.here>
maildir-store = ~/.mail
folders-sort = inbox,unread,starred,sent,draft,trash,mail
query-map     = ~/.config/aerc/<your-map>.map
```

- Create `config/aerc/<your-map>.map` with the following:

```
inbox=tag:inbox
unread=tag:unread and tag:inbox and not tag:sent
sent=tag:sent
starred=tag:flagged
trash=tag:trash
draft=tag:draft

```

- Start `aerc`
