<script setup lang="ts">
import MyUiButton from "~/components/ui/my-ui-button/index.vue";
</script>

<template>
  <div class="py-5 border-b border-white/10">
    <div class="flex flex-col sm:flex-row">
      <div class="">
        <NuxtImg
          class="rounded-xl w-[400px] h-[400px]"
          src="https://i.pinimg.com/736x/af/42/42/af4242eb0bc437479946b63296a94afd.jpg"
        />
      </div>
      <div
        class="w-full pl-0 sm:pl-10 flex flex-col justify-between pt-1 ms:pt-0"
      >
        <div class="flex flex-col sm:flex-row sm:items-center justify-between">
          <p class="font-bold text-2xl lg:text-4xl">Сведение и мастеринг</p>
          <div class="flex flex-row items-center">
            <p class="font-semibold text-xl lg:text-2xl">от 2000</p>
            <Icon
              size="25"
              name="material-symbols-light:currency-ruble-rounded"
            />
          </div>
        </div>
        <p class="text-xs mb-[25px] dark:opacity-70 pt-2 ms:pt-0">
          Предлагаю вам качественное сведение и мастеринг вашего будущего
          хита!<br />
          Что входит в услугу?
          <br />
          - Грамотное выстраивание баланса инструментов<br />
          - Удаление шумов, щелчков и прочего мусора из вокала<br />
          - Динамическая и частотная обработка (компрессия, эквализация,
          сатурация и т.д)<br />
          - Пространственная обработка (реверберации, дилеи, хорусы)<br />
          - Коррекция вокала и сведение с битом<br />
          - Автотюн по желанию<br />
          - Фишки/эффекты: дилей, фильтр, реверс, реверберация, нарезка
          голоса/минуса, работа с панорамой, глитч и др.<br />
          - Мастеринг включен в стоимость<br />

          mРабота выполняется от 1 до 7 дней! Цена зависит от сложности проекта.
        </p>
        <NuxtLink class="hidden sm:block" to="/catalog">
          <MyUiButton class="">Подробнее...</MyUiButton>
        </NuxtLink>
        <MyUiButton class="sm:hidden">Подробнее...</MyUiButton>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
