<script setup lang="ts">
import { ref } from "vue";
import MyUiButton from "~/components/ui/my-ui-button/index.vue";
import type { LastReleasesRecord } from "~/lib/pocketbase-types";
import { usePocketBase } from "~/lib/usePocketbase";
import MyLoading from "@/components/ui/loading/index.vue";

const pb = usePocketBase();

const slides = ref<LastReleasesRecord[]>([]);
const urlCover = ref<string[]>([]);
const isFullScreen = ref<boolean>(false);

onMounted(async () => {
  slides.value = await pb.collection("last_releases").getFullList();
  urlCover.value = slides.value
    .filter((slide) => slide.cover)
    .map((slide) => {
      return pb.files.getURL(slide, slide.cover!, {
        thumb: "3000x3000",
      });
    });

  console.log("URL обложек:", urlCover.value);
  console.log(slides.value);
});

const currentSlideIndex = ref(0);

const nextSlide = () => {
  currentSlideIndex.value = (currentSlideIndex.value + 1) % slides.value.length;
  console.log(currentSlideIndex.value);
};

const prevSlide = () => {
  currentSlideIndex.value =
    (currentSlideIndex.value - 1 + slides.value.length) % slides.value.length;
  console.log(currentSlideIndex.value);
};

const fullScreen = async () => {
  if (!isFullScreen.value) {
    isFullScreen.value = !isFullScreen.value;

    await nextTick();

    window.scrollTo({
      top: document.documentElement.scrollHeight,
      behavior: "smooth",
    });
  } else {
    isFullScreen.value = !isFullScreen.value;
  }
};

const getIndex = () => {
  return currentSlideIndex.value;
};
</script>

<template>
  <div class="">
    <div
      v-if="!(slides.length <= 0)"
      :class="[
        'relative overflow-hidden ',
        isFullScreen ? 'h-screen' : 'h-[calc(100vh-65px)]',
      ]"
    >
      <img
        :src="urlCover[currentSlideIndex]"
        alt="Background"
        class="absolute h-full w-full object-cover blur-xl scale-200 opacity-30 light:opacity-70"
      />
      <div class="relative z-10 flex h-full justify-center items-center">
        <div class="flex flex-col items-center">
          <div class="">
            <NuxtLink to="/links">
              <NuxtImg
                class="w-[250px] sm:w-[400px] rounded-3xl hover:opacity-90 cursor-pointer transition-all border border-white/20"
                :src="urlCover[currentSlideIndex]"
              />
            </NuxtLink>
          </div>
          <div class="flex flex-col justify-center items-center pt-4">
            <p
              class="font-bold text-2xl sm:text-5xl text-white light:text-black/70"
            >
              {{ slides[currentSlideIndex]?.artist }}
            </p>
            <p
              class="font-bold text-xl sm:text-4xl pt-2 text-white/80 light:text-black/30"
            >
              {{ slides[currentSlideIndex]?.title }}
            </p>
          </div>
          <div class="pt-4">
            <MyUiButton>
              <NuxtLink :to="slides[currentSlideIndex]?.url_on_track">
                <div class="flex items-center gap-2 text-black/80 text-xl">
                  <Icon name="solar:play-bold" size="24" />
                  <p>Слушать</p>
                </div>
              </NuxtLink>
            </MyUiButton>
          </div>
        </div>
        <div class="">
          <button
            v-if="!(slides.length <= 1)"
            @click="nextSlide"
            class="absolute cursor-pointer right-3 sm:right-5 top-1/2 -translate-y-1/2 transform ml-4 rounded-full bg-white/30 light:bg-black p-3 text-white backdrop-blur-md transition hover:bg-white/50 opacity-30 hover:opacity-90"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-4 sm:h-6 w-4 sm:w-6"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 5l7 7-7 7"
              />
            </svg>
          </button>
          <button
            v-if="!(slides.length <= 1)"
            @click="prevSlide"
            class="absolute cursor-pointer left-[-5px] rotate-180 sm:left-5 top-1/2 -translate-y-1/2 transform ml-4 rounded-full bg-white/30 light:bg-black p-3 text-white backdrop-blur-md transition hover:bg-white/50 opacity-30 hover:opacity-90"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-4 sm:h-6 w-4 sm:w-6"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 5l7 7-7 7"
              />
            </svg>
          </button>
          <button
            @click="fullScreen"
            class="fixed bottom-0 cursor-pointer right-6 -translate-y-1/2 transform ml-4 rounded-2xl bg-white/30 light:bg-black p-3 text-white backdrop-blur-md transition hover:bg-white/20 opacity-30 hover:opacity-90"
          >
            <Icon
              v-if="!isFullScreen"
              class="flex hover:animate-pulse"
              name="solar:full-screen-broken"
              size="24"
            />
            <Icon
              v-else
              class="flex hover:animate-pulse"
              name="solar:quit-full-screen-broken"
              size="24"
            />
          </button>
        </div>
      </div>
    </div>
    <div
      v-else
      class="flex flex-1 h-[calc(100vh-65px)] justify-center items-center"
    >
      <MyLoading size="lg" />
    </div>
  </div>
</template>

<style scoped></style>
