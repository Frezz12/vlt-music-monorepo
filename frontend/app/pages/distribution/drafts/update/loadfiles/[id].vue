<script lang="ts" setup>
import ProfileLayout from "@/layouts/profile.vue";
import type { DraftRecord } from "~/lib/pocketbase-types";
import { usePocketBase } from "~/lib/usePocketbase";

const pb = usePocketBase();
const route = useRoute()
const draftId = route.params.id as string
const draft = ref<DraftRecord | null>(null)

onMounted(async () => {
  try {
    draft.value = await pb.collection('draft').getOne(draftId)
    console.log(draft.value)
  } catch (err) {
    console.log(err)
  }
})

</script>

<template>
  <ProfileLayout>
    <div class="pl-5">
      <div class="flex w-[600px] lg:w-[1020px] justify-start ">
        <div class="flex">
          <div class="w-[200px] h-[200px]">
            <NuxtImg class=" rounded-2xl" :src="pb.files.getURL(draft, draft?.logo)" />
          </div>
          <div class="flex flex-col pl-6 justify-between py-2">
            <div class="">
              <p class=" text-4xl ">{{ draft?.realese_name }}</p>
              <div class="flex items-center text-2xl opacity-70 gap-2">
              <p>{{ draft?.main_artist }}</p>
              <p>feat. </p>
              <p>{{ draft?.invate_artist }}</p>
              </div>
            </div>
            <div class="flex items-center gap-1 opacity-70">
              <Icon size="18" name="solar:calendar-date-broken" />
              <p>{{ draft?.realese_data?.split(' ')[0] }}</p>
            </div>
          </div>
        </div>
      </div>
      </div>
  </ProfileLayout>
</template>


<style></style>