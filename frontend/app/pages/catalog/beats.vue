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
          <p class="font-bold text-2xl lg:text-4xl">Биты</p>
          <div class="flex flex-row items-center">
            <p class="font-semibold text-xl lg:text-2xl">от 1000</p>
            <Icon
              size="25"
              name="material-symbols-light:currency-ruble-rounded"
            />
          </div>
        </div>
        <p class="text-xs mb-[25px] opacity-70 pt-2 ms:pt-0">
          Требования к загрузке:
          <br />
          1. Трек форматом Waw и 44100 Ггц;<br />
          2. Обложка форматом 3000 x 3000 пикселей;<br />
          3. Не FREE формат бита,только те,кто приобрел полные права или
          аренду.<br />
          4. Необходимо сразу написать свое ФИО и ФИО битмейкера,который писал
          бит. Если трек с фитом,так же необходимо ФИО человека с которым
          коллаборация;<br />
          5. Жанр релиза;<br />
          6. Если есть ли мат в треке необходимо написать об этом;<br />
          7. Написать текст песни<br />
          8. Быстрая загрузка трека на площадки<br />
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
