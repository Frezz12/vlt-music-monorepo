<script setup lang="ts">
import MyUiButton from "~/components/ui/my-ui-button/index.vue";
import MyUiBlueButton from "@/components/ui/ui-blue-button/index.vue";
</script>

<template>
  <div class="container mx-auto h-screen px-[60px] py-10">
    <div class="flex flex-col lg:flex-row items-center">
      <div class="">
        <NuxtImg
          class="w-[300px] h-[300px] sm:w-[500px] sm:h-[500px] rounded-2xl"
          src="https://i.pinimg.com/736x/32/b6/b0/32b6b0ce20e6339e58858671b7d3e88f.jpg"
        />
      </div>
      <div class="pl-0 sm:pl-10 pt-3 items-center">
        <div class="flex flex-col sm:flex-row sm:items-center justify-between">
          <p class="font-bold text-2xl lg:text-4xl">Дистребьюция</p>
          <div class="flex flex-row items-center">
            <p class="font-semibold text-blue-300 text-xl lg:text-2xl">
              от 41000
            </p>
            <Icon
              size="25"
              name="material-symbols-light:currency-ruble-rounded"
            />
          </div>
        </div>
        <p class="sm:text-xs mb-[25px] opacity-70 pt-6 ms:pt-0">
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
        <div
          class="flex flex-col sm:flex sm:flex-row justify-between items-center"
        >
          <NuxtLink class="" to="/catalog/distribution-page">
            <MyUiButton class="w-[300px] py-3 sm:w-[250px]"
              >Загрузить релиз</MyUiButton
            >
          </NuxtLink>
          <NuxtLink
            class="pt-3 sm:pt-0 sm:pl-3"
            to="/catalog/distribution-page"
          >
            <MyUiBlueButton class="w-[300px] sm:w-[250px] py-3"
              >Условия дистребьюции</MyUiBlueButton
            >
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
