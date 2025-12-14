<!-- components/UiSpinner.vue -->
<script setup lang="ts">
interface Props {
  size?: "sm" | "md" | "lg";
  color?: string;
  thickness?: number;
  speed?: string;
}

const props = withDefaults(defineProps<Props>(), {
  size: "md",
  color: "#CCFF00",
  thickness: 2,
  speed: "0.75s",
});

const sizeMap = {
  sm: "1rem",
  md: "2rem",
  lg: "3rem",
};

const spinnerStyle = computed(() => ({
  width: sizeMap[props.size],
  height: sizeMap[props.size],
  border: `${props.thickness}px solid ${props.color}20`,
  borderTop: `${props.thickness}px solid ${props.color}`,
  animation: `spin ${props.speed} linear infinite`,
}));
</script>

<template>
  <div class="spinner" :style="spinnerStyle" />
</template>

<style scoped>
.spinner {
  border-radius: 50%;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}
</style>
