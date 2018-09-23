<template>
    <div class="title">
        {{ print() }}
    </div>
</template>

<script>
import msg from './msg';

export default {
    methods: {
        print() {
            return `Hello-- ${msg}!`;
        },
    }
};
</script>

<style scoped>
.title {
    font-size: 24px;
}
</style>
