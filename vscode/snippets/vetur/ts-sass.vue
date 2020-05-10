<template>
<h1>{{ text }}</h1>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator';

@Component
export default class Foo extends Vue {
  text = 'bar';
}
</script>

<style scoped lang="scss">

</style>