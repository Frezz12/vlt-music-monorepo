<script setup lang="ts">
import UiButton from "~/components/ui/my-ui-button/index.vue";
</script>

<template>
  <div class="py-5 border-b border-white/10">
    <div class="flex flex-col sm:flex-row">
      <div class="">
        <NuxtImg
          width="400"
          height="400"
          class="rounded-xl"
          src="/image/catalog/distreb.jpg"
        />
      </div>
      <div
        class="w-full pl-0 sm:pl-10 flex flex-col justify-between pt-1 ms:pt-0"
      >
        <div class="flex flex-col sm:flex-row sm:items-center justify-between">
          <p class="font-bold text-2xl lg:text-4xl">Обложки / Дизайн</p>
          <div class="flex flex-row items-center">
            <p class="font-semibold text-xl lg:text-2xl">от 1000</p>
            <Icon
              size="25"
              name="material-symbols-light:currency-ruble-rounded"
            />
          </div>
        </div>
        <p class="text-xs mb-[25px] opacity-70 pt-2 ms:pt-0">
          Обложки на заказ<br />
          В формате 3000х3000<br />
          <br />
          • Любая Ваша задумка, любая ваша фантазия - будет полностью
          реализована!<br />
          • Вместе с вами мы прорабатываем все до мелочей и доводим все до
          идеала вашего виденья.<br />
          • Одни из лучших цен на рынке. "Цена = качество". За работу я беру
          предоплату 100 процентов.<br />
          • За срочность, и многочисленные переделки берётся дополнительная
          плата.
        </p>
        <NuxtLink class="hidden sm:block" to="/catalog">
          <UiButton class="">Подробнее...</UiButton>
        </NuxtLink>
        <UiButton class="sm:hidden">Подробнее...</UiButton>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
