<template>
  <div></div>
</template>

<script>
import name from './config';

const fn = (str) => str;

export default {
    methods: {
        print() {
          return fn(`${name}`);
        },
    }
};
</script>

<style lang="scss" scoped>
.suggestion-list {
  position: absolute;
  top: 100%;
  left: 0;
  width: 100%;
  // z-index: $z-index-high;
  // padding-left: 0;
  // margin-top: 0;
  // margin-bottom: $space-small;
  // text-align: left;
  // list-style-type: none;
  // background-color: $color-white;
  // border: $border-width solid $color-gray-light;
  // border-bottom-right-radius: $border-radius;
  // border-bottom-left-radius: $border-radius;
  // box-shadow: $box-shadow-tiny;

  // li {
  //   &:hover,
  //   &:active,
  //   &.selected {
  //     background: $color-gray-lightest;
  //   }
  // }
}
</style>

<style lang="scss">
.suggestion-highlight {
  color: inherit;
  background: transparent;
}
</style>
