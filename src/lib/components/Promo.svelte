<script>
  import { base } from "$app/paths";
  export let id;
  export let name;
  const version = 1;
</script>

<picture>
  <source srcset="{base}/projects/{name}/{id}.webp?v={version}" type="image/webp">
  <img src="{base}/projects/{name}/{id}.png?v={version}" alt="" style="width: 100%; aspect-ratio: 16 / 9;">
</picture>

<style>
  img {
    width: 100%;
    aspect-ratio: 16 / 9;
  }
</style>
