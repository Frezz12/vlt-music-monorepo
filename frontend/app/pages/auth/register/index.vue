<script lang="ts" setup>
import MyUiButton from "@/components/ui/my-ui-button/index.vue";
import { useAuth, usePocketBase } from "~/lib/usePocketbase";

const pb = usePocketBase();
const { register, error } = useAuth();

const comfirmAuth = ref<boolean>(false)

const data = reactive({
  nikname: '',
  email: '',
  password: '',
  confirmPassword: '',
  refID: '',
});

// const errNikname = ref<boolean>(false);
const errMessage = ref<string>('')

const handleRegister = async () => {
  console.log(comfirmAuth.value)
  if (comfirmAuth.value) {
    if (data.nikname && data.email && data.password && data.confirmPassword) {
      errMessage.value = ""
      if (data.password === data.confirmPassword) {
        errMessage.value = ""
        if (data.password.length >= 6) {
          errMessage.value = ""

          console.log(data)

          await register({
            nikname: data.nikname,
            email: data.email,
            password: data.password,
            confirmPassword: data.confirmPassword,
            refID: data.refID
          })
          if (error.value) {
            errMessage.value = error.value
          }

        } else {
          errMessage.value = "Пароль должен быть не меньше 6 символов!"
        }
      } else {
        errMessage.value = "Пароли не совпадают!"
      }
    } else {
      errMessage.value = "Все обязательные поля должны быть заполнены!"
    }
  } else {
    errMessage.value = "Премите пользовательское соглашение"
  }
}

</script>

<template>
  <div class="container mx-auto h-screen">
    <div class="flex justify-center items-center pt-20">
      <div class="flex flex-col justify-between items-center">
        <p class="text-4xl sm:text-6xl font-bold">Регистрация</p>
        <div class="py-10 px-5 sm:px-0">
          <div class="flex justify-starts text-[13px] pb-2 opacity-80">
            <p>Есть аккаунта?</p>
            <NuxtLink to="/auth/login" class="pl-1 text-[#CCFF00] cursor-pointer">Войти</NuxtLink>
          </div>
          <div class="flex flex-col gap-3">
            <div v-if="errMessage" class="flex items-center text-red-400">
              <Icon name="solar:danger-triangle-broken" class=" " size="14" />
              <p class="pl-1 text-sm">{{ errMessage }}</p>
            </div>
            <UFormField label="Отображаемое имя*" size="md">
              <UInput v-model="data.nikname" type="text" placeholder="Ваш никнейм" class="w-full" />
            </UFormField>
            <UFormField label="Email*" size="md">
              <UInput v-model="data.email" placeholder="Email" class="w-full" />
            </UFormField>
            <UFormField label="Пароль*" size="md" description="Не меньше 6 символов">
              <UInput v-model="data.password" type="password" placeholder="Придумайте пароль" class="w-full" />
            </UFormField>
            <UFormField label="Повторите пароль*" size="md">
              <UInput v-model="data.confirmPassword" type="password" placeholder="Повторите пароль" class="w-full" />
            </UFormField>
            <UFormField label="ID человека который вас пригласил (необязательно)" size="md">
              <UInput v-model="data.refID" type="text" placeholder="yjl4sj69qsw8t0o" class="w-full" />
            </UFormField>
            <div class="flex items-center gap-2 opacity-60">
              <p class="text-md">*</p>
              <p class="text-md">-</p>
              <p class="text-sm">Обязательное поле</p>
            </div>
          </div>
          <div class="flex items-center gap-1">
            <UCheckbox v-model="comfirmAuth" />
            <p class="pl-2 sm:pl-1 text-[13px]">
              Создавая аккаунт, Я соглашаюсь с Условиями сервиса
            </p>
            <NuxtLink class=" text-[13px] text-[#CCFF00]" to="#">
              VLT.MUSIC
            </NuxtLink>
          </div>
        </div>
        <div class="">
          <MyUiButton @click="handleRegister" class="px-14 py-3">Зарегистрироватся</MyUiButton>
        </div>
      </div>
    </div>
  </div>
</template>

<style></style>
