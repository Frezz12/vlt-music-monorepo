<script setup lang="ts">
import MyUiButton from "~/components/ui/my-ui-button/index.vue";
import NavigationProfileBar from "~/components/ui/navigation-profile-bar/index.vue";
</script>

<template>
  <div
    class="flex items-center justify-center pt-10"
  >
    <div class="flex">
      <div class="border-r border-white/10 pr-4">
        <NavigationProfileBar />
      </div>
      <div class="">
        <slot></slot>
      </div>
    </div>
  </div>
</template>
