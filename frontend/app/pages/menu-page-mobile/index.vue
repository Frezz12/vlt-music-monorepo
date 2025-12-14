<script setup lang="ts">
import MyUiButton from "../../components/ui/my-ui-button/index.vue";
import { useAuth } from "~/lib/usePocketbase";

const auth = useAuth();

const isAuthenticated = ref<boolean>(false);

onMounted(() => {
  if (auth.isValid.value) {
    console.log(auth.isValid.value);
    isAuthenticated.value = true;
    return;
  }
  isAuthenticated.value = false;
});
</script>

<template>
  <div class="p-1 sm:hidden">
    <div class="">
      <div class="p-5">
        <ul class="flex flex-col justify-between pt-[100px]">
          <li
            class="border border-[#CCFF00] rounded-md flex justify-center py-2 my-2"
          >
            <NuxtLink class="" to="/">Главная</NuxtLink>
          </li>
          <li
            class="border border-[#CCFF00] rounded-md flex justify-center py-2 my-2"
          >
            <NuxtLink class="" to="/">Линки</NuxtLink>
          </li>
          <li
            class="border border-[#CCFF00] rounded-md flex justify-center py-2 my-2"
          >
            <NuxtLink class="" to="/catalog">Услуги</NuxtLink>
          </li>
        </ul>
        <div v-if="!isAuthenticated" class="flex justify-center pt-2">
          <MyUiButton class="w-full py-3">
<!--            <NuxtLink to="/auth/login">Войти</NuxtLink>-->
          </MyUiButton>
        </div>
        <div v-if="isAuthenticated" class="flex justify-center pt-2">
          <MyUiButton class="w-full py-3">
            <NuxtLink to="/profile">Личный кабинет</NuxtLink></MyUiButton
          >
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
