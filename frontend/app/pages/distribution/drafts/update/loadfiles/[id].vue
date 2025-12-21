<script lang="ts" setup>
import ProfileLayout from "@/layouts/profile.vue";
import type { DraftRecord, TrackRecord } from "~/lib/pocketbase-types";
import { usePocketBase } from "~/lib/usePocketbase";
import * as z from 'zod'

const pb = usePocketBase();
const route = useRoute()
const draftId = route.params.id as string
const draft = ref<DraftRecord | null>(null)

const tracks = ref<TrackRecord[] | null>(null)

const MAX_FILE_SIZE = 5 * 1024 * 1024 // 2MB
const MIN_DIMENSIONS = { width: 3000, height: 3000 }
const MAX_DIMENSIONS = { width: 3000, height: 3000 }
const ACCEPTED_IMAGE_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp']

onMounted(async () => {
  try {
    draft.value = await pb.collection('draft').getOne(draftId)
    for (var i = 0; i < draft.value!.tracks!.length; i++) {
      const trackID = draft.value?.tracks![i]
      console.log(trackID)
      if (trackID){
        const track = await pb.collection('track').getOne(trackID)
        tracks.value?.push(track)
      }
    }
    console.log(tracks.value)
  } catch (err) {
    console.log(err)
  }
})


const formatBytes = (bytes: number, decimals = 2) => {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const dm = decimals < 0 ? 0 : decimals
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Number.parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i]
}

const schema = z.object({
  avatar: z
    .instanceof(File, {
      message: 'Пожалуйста, выберите файл изображения.'
    })
    .refine((file) => file.size <= MAX_FILE_SIZE, {
      message: `Изображение слишком большое. Пожалуйста, выберите изображение меньшего размера. ${formatBytes(MAX_FILE_SIZE)}.`
    })
    .refine((file) => ACCEPTED_IMAGE_TYPES.includes(file.type), {
      message: 'Пожалуйста, загрузите корректный файл изображения. (wav, mp3).'
    })
    .refine(
      (file) =>
        new Promise((resolve) => {
          const reader = new FileReader()
          reader.onload = (e) => {
            const img = new Image()
            img.onload = () => {
              const meetsDimensions =
                img.width >= MIN_DIMENSIONS.width &&
                img.height >= MIN_DIMENSIONS.height &&
                img.width <= MAX_DIMENSIONS.width &&
                img.height <= MAX_DIMENSIONS.height
              resolve(meetsDimensions)
            }
            img.src = e.target?.result as string

          }
          reader.readAsDataURL(file)
        }),
      {
        message: `The image dimensions are invalid. Please upload an image between ${MIN_DIMENSIONS.width}x${MIN_DIMENSIONS.height} and ${MAX_DIMENSIONS.width}x${MAX_DIMENSIONS.height} pixels.`
      }
    )
})

type Schema = z.output<typeof schema>

const state = reactive<Partial<Schema>>({
  avatar: undefined
})

function createObjectUrl(file: File): string {
  return URL.createObjectURL(file)
}

async function uploadAvatarToServer(file: File) {
  if (!state.avatar) {
    console.error('Пожалуйста, выберите файл аватарки');
    return;
  }

  try {
    const formData = new FormData();

    formData.append('audiofile', state.avatar);

    const updatedUser = await pb.collection('track').update(
      draftId,
      formData
    );

    draft.value = await pb.collection('draft').getOne(draftId)
  } catch (error: any) {
    console.error('Ошибка загрузки:', error);
  }
}

const data = reactive({
  urlLogo: undefined as File | undefined,
})

watch(() => state.avatar, () => {
  console.log(state.avatar)
  uploadAvatarToServer(state.avatar!)
})

const createTrack = async () => {
  try {
    const track = await pb.collection('track').create()
    tracks.value?.push(track)

    const draftTracks = draft.value?.tracks
    draftTracks!.push(track.id)

    console.log(draftTracks)


    pb.collection('draft').update(draftId, {
      'tracks': draftTracks
    })
  } catch (err) {
    console.log(err)
  }
}

onMounted(async() => {
  try {
    console.log(draft.value)

   
  } catch (err) {
    console.log(err)
  }
})
</script>

<template>
  <ProfileLayout>
    <div class="pl-5">
      <div class="flex flex-col w-[600px] lg:w-[1020px] justify-start">
        <div class="flex border-b w-full border-white/20 pb-3">
          <div class="w-[200px] h-[200px]">
            <NuxtImg class=" w-full h-full rounded-2xl" :src="pb.files.getURL(draft, draft?.logo)" />
          </div>
          <div class="flex flex-col pl-6 justify-between py-2">
            <div class="">
              <p class=" text-4xl ">{{ draft?.realese_name }}</p>
              <div class="flex items-center text-2xl opacity-70 gap-2">
                <p>{{ draft?.main_artist }}</p>
                <div v-if="draft?.invate_artist" class="">
                  <p>feat. </p>
                  <p>{{ draft?.invate_artist }}</p>
                </div>
              </div>
            </div>
            <div class="flex items-center gap-1 opacity-70">
              <Icon size="18" name="solar:calendar-date-broken" />
              <p>{{ draft?.realese_data?.split(' ')[0] }}</p>
            </div>
          </div>
        </div>
        <div class="">
          <div class=""> 
            <div v-for="value in tracks" class="">
              {{ value.id }}
            </div>
          </div>
          <div class="flex justify-center pt-6">
            <UModal title="Добавление файлов">
              <UButton @click="createTrack" size="xl" label="Добавить аудиофайл" color="neutral" variant="subtle" />
              <template #body>
                <UFileUpload variant="area" />
              </template>
            </UModal>
          </div>
        </div>
      </div>
    </div>
  </ProfileLayout>
</template>
