<script lang="ts" setup>
import MyUiInput from "@/components/ui/ui-input/index.vue";
import MyUiButton from "~/components/ui/my-ui-button/index.vue";
import {useAuth, useAuthenticated} from "~/lib/usePocketbase";

const auth = useAuth()


const email = ref<string>("")
const password = ref<string>("")

const handleLogin = async () => {
  console.log(email.value)
  console.log(password.value)

  try {
    await auth.authUserWithPassword({
      email: email.value,
      password: password.value,
    })
    await navigateTo( '/', { external: true })

  } catch (error) {
    console.log(error)
  }
}

useAuthenticated()
</script>

<template>
  <div class="container mx-auto ">
    <div class="flex justify-center items-center pt-[200px]">
      <div class="flex flex-col justify-between items-center">
        <p class="text-6xl font-bold">Войти</p>
        <div class="py-10">
          <div class="flex justify-starts text-[13px] pb-2 opacity-80">
            <p>Нет аккаунта?</p>
            <NuxtLink
              to="/auth/register"
              class="pl-1 text-[#CCFF00] cursor-pointer"
              >Зарегистрироватся</NuxtLink
            >
          </div>
          <MyUiInput placeholder="Email" type="email" v-model="email" />
          <MyUiInput class="mt-3" type="password" placeholder="Password" v-model="password"  />
          <div class="">
            <!--                <UiCheckBox class="pt-2">-->
            <!--                  <p class="pl-1 text-[13px]">Создавая аккаунт, Я соглашаюсь с Условиями сервиса VLT.MUSIC</p>-->
            <!--                </UiCheckBox>-->
          </div>
        </div>
        <div class="">
          <MyUiButton @click="handleLogin" class="px-14 py-3">Войти</MyUiButton>
        </div>
      </div>
    </div>
  </div>
</template>

<style></style>
