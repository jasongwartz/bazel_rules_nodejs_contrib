<template>
    <div class="title">
        {{ print() }}
    </div>
</template>

<script>
import { name } from './config';

export default {
    methods: {
        print() {
            return `Hello ${name}!`;
        },
    }
};
</script>

<style lang="scss" scoped>
$color: red;

.title {
    color: $color;
    font-size: 24px;
}
</style>
