<script>
    import { balancer } from '$lib/actions/balancer';
</script>

<section>
	<h3 use:balancer class="mono">
		<slot name='subtitle' />
	</h3>
</section>

<style>
    h3 {
		font-weight: 300;
		font-size: 1.3em;
		max-width: 420px;
	}
</style>

