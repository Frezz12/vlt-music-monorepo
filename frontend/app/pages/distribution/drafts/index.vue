<script lang="ts" setup>
import ProfileLayout from "@/layouts/profile.vue";
import type { DraftRecord } from "~/lib/pocketbase-types";
import { usePocketBase } from "~/lib/usePocketbase";

const pb = usePocketBase()
const drafts = ref<DraftRecord[] | null>(null)

onMounted(async () => {
    try {
        drafts.value = await pb.collection('draft').getFullList({
            filter: pb.authStore.record?.id ? `author = "${pb.authStore.record?.id}"` : ''
        })
    } catch (err) {
        console.log(err)
    }
})

const openDraft = (id: string) => {
    navigateTo(`/distribution/drafts/update/${id}`)
}

const deleteDraft = async (id: string) => {
    try {
        await pb.collection('draft').delete(id)
        drafts.value = await pb.collection('draft').getFullList({
            filter: pb.authStore.record?.id ? `author = "${pb.authStore.record?.id}"` : ''
        })
    } catch (err) {
        console.log(err)
    }
}
</script>

<template>
    <ProfileLayout>
        <div class="pl-5">
            <div class="flex flex-1 flex-col  w-[600px] lg:w-[1020px] justify-between">
                <div class="w-full">
                    <UInput class="w-full" icon="i-lucide-search" size="xl" variant="outline" placeholder="Поиск..." />
                </div>
                <div v-for="item in drafts" class="flex flex-col border mt-3 border-white/20 p-3 rounded-2xl">
                    <div class="flex items-center
                    ">
                        <div v-if="item.logo" class="w-16 h-16 ">
                            <NuxtImg class="rounded-xl w-full h-full" :src="pb.files.getURL(item, item.logo!)" />
                        </div>
                        <div v-else class="w-16 h-16 flex items-center justify-center 
                    rounded-xl bg-white/20">
                            <Icon class=" opacity-70" size="32" name="solar:archive-broken" />
                        </div>
                        <div class="flex flex-1 items-center justify-between">
                            <div class="">
                                <p class="pl-3 text-xl">{{ item.realeseName }}</p>
                            </div>
                            <div class="flex gap-2">
                                <UButton @click="openDraft(item.id)" class=" cursor-pointer" icon="solar:eye-broken" size="md" color="primary" variant="soft" />
                                <UButton @click="openDraft(item.id)" class=" cursor-pointer" icon="solar:pen-broken" size="md" color="primary" variant="soft" />
                                <UButton @click="deleteDraft(item.id)" class=" cursor-pointer" icon="solar:trash-bin-2-broken" size="md" color="error" variant="soft" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </ProfileLayout>
</template>