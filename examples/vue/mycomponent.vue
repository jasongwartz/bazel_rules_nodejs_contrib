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

<style scoped>
.title {
    font-size: 24px;
}
</style>
