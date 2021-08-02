# tawhiri-downloader-container

_tawhiri-downloader-container_ is a containised version of [_tawhiri-downloader_](https://github.com/cuspaceflight/tawhiri-downloader).

## Notes

- The latest version of this container is available from `ghcr.io/projecthorus/tawhiri-downloader-container:latest`.
- Downloaded data sets are stored in `/srv/tawhiri-datasets`. These need to be made avilable to [_tawhiri-container_](https://github.com/projecthorus/tawhiri-container), and it is recommend that `/srv` is shared using a method such as a bind mount or volume.
- A timezone must be passed to the container, either by setting the `TZ` environment variable, or by bind mounting `/etc/localtime` in to the container from the host system.

## Examples

To run in _daemon_ mode:

```sh
docker run --rm -i -t -e TZ=UTC -v /opt/tawhiri:/srv ghcr.io/projecthorus/tawhiri-downloader-container:latest daemon
```
