<script setup lang="ts">
import MyUiButton from "../ui/my-ui-button/index.vue";
import { useAuth } from "~/lib/usePocketbase";
import { usePocketBase } from "~/lib/usePocketbase";
import type { UsersRecord } from "~/lib/pocketbase-types";

const auth = useAuth();
const pb = usePocketBase();

const isAuthenticated = ref<boolean>(false);
const balance = ref<number>(0);
const bonusBalance = ref<number>(0);

const user = ref<UsersRecord>();

onMounted(async () => {
  if (auth.isValid.value) {
    console.log(auth.isValid.value);
    isAuthenticated.value = true;

    user.value = await pb.collection("users").getOne(pb.authStore.record?.id!);
    console.log(user.value);

    balance.value = user.value?.balance || 0;
    console.log(balance.value);

    bonusBalance.value = user.value?.bonus_balance || 0;
    console.log(balance.value);
    return;
  }
  isAuthenticated.value = false;
});
</script>

<template>
  <header class="flex border-b border-b-white/20 light:border-b-black/20">
    <div class="container mx-auto hidden sm:block">
      <nav class="relative flex items-center h-16 px-[60px] w-full">
        <!-- Логотип слева -->
        <NuxtLink to="/" className="absolute left-0 flex justify-center items-center gap-2">
          <!--          <NuxtImg class="w-[50px]" src="logo.png" />-->
          <span class="font-black light:text-black text-3xl">VLT</span>
        </NuxtLink>

        <!-- Меню по центру -->
        <div
          class="absolute left-1/2 transform -translate-x-1/2 hidden md:flex items-center gap-10 text-md font-medium">
          <NuxtLink to="/"
            class="text-white/80 hover:text-white light:text-neutral-700 light:hover:text-neutral-500 hover:glow transition-colors">
            Главная
          </NuxtLink>
          <NuxtLink to="/links"
            class="text-white/80 hover:text-white light:text-neutral-700 light:hover:text-neutral-500 hover:glow transition-colors">
            Линки
          </NuxtLink>
          <NuxtLink to="/catalog"
            class="text-white/80 hover:text-white light:text-neutral-700 light:hover:text-neutral-500 hover:glow transition-colors">
            Услуги
          </NuxtLink>
        </div>

        <!-- Элементы управления справа -->
        <div class="absolute right-0 flex items-center gap-4">
          <div v-if="isAuthenticated" class="border-2 border-[#CCFF00] rounded-full text-black/80">
            <div class="text-white/70 cursor-pointer flex flex-row p-1 px-1 gap-1 items-center">
              <div @click="navigateTo('/finance/balance')"
                class="flex flex-row text-white/80 hover:bg-white/20 light:hover:bg-black/10 rounded-2xl light:text-black/80 p-1 px-3 gap-1">
                <Icon name="solar:ruble-broken" size="16" />
                <div class="text-xs">
                  <p>{{ balance }}</p>
                </div>
              </div>
              <div @click="navigateTo('/finance/bonus-balance')"
                class="text-black/80 cursor-pointer flex flex-row p-1 px-2 gap-1 bg-[#CCFF00] hover:bg-[#CCFF00]/70 rounded-2xl">
                <Icon name="solar:wad-of-money-broken" size="16" />
                <div class="text-xs">
                  <p>{{ bonusBalance }}</p>
                </div>
              </div>
            </div>

          </div>
          <NuxtLink to="/profile/notification">
            <div v-if="false" class="">
              <UChip>
                <UButton class="cursor-pointer" icon="solar:bell-bing-broken" color="neutral" variant="subtle" />
              </UChip>
            </div>
            <div v-if="true" class="">
                <UButton class="cursor-pointer" icon="solar:bell-bing-broken" color="neutral" variant="subtle" />
            </div>
          </NuxtLink>
          <UColorModeButton>
            <template #fallback>
              <UButton loading variant="ghost" color="neutral" />
            </template>
          </UColorModeButton>
          <NuxtLink v-if="!isAuthenticated" to="/auth/login">
            <div class="flex bg-[#CCFF00] p-2 rounded-xl text-black items-center justify-center">
              <Icon name="solar:login-3-bold" size="24" />
            </div>
          </NuxtLink>
          <NuxtLink v-if="isAuthenticated" to="/profile">
            <div class="flex bg-[#CCFF00] p-2 rounded-xl text-black/80 items-center justify-center">
              <Icon name="solar:user-broken" size="24" />
            </div>
          </NuxtLink>
        </div>
      </nav>
    </div>
    <div class="container mx-auto sm:hidden">
      <nav class="relative flex items-center h-16 px-[60px] w-full">
        <NuxtLink to="/" className="absolute left-0 flex justify-center items-center gap-2">
          <span class="font-medium text-white">VLT</span>
        </NuxtLink>

        <div class="absolute left-1/2 transform -translate-x-1/2 hidden md:flex items-center gap-10 text-md">
          <NuxtLink to="/" class="text-white/80 hover:text-white hover:glow transition-colors">
            Главная
          </NuxtLink>
          <NuxtLink to="/links" class="text-white/80 hover:text-white hover:glow transition-colors">
            Линки
          </NuxtLink>
          <NuxtLink to="/catalog" class="text-white/80 hover:text-white hover:glow transition-colors">
            Услуги
          </NuxtLink>
        </div>
        <NuxtLink class="absolute right-0 flex" to="/menu-page-mobile">
          <Icon size="40" name="material-symbols-light:menu-rounded" />
        </NuxtLink>
      </nav>
    </div>
  </header>
</template>

<style scoped></style>
