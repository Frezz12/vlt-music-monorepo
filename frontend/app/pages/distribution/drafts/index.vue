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
    } catch (err ) {
        console.log(err)
    }
})

const openDraft = (id: string) => {
    navigateTo(`/distribution/drafts/update/${id}`)
}
</script>

<template>
    <ProfileLayout>
        <div class="pl-5">
            <div class="flex flex-1 flex-col  w-[600px] lg:w-[1020px] justify-between">
                <div class="w-full">
                     <UInput class="w-full" icon="i-lucide-search" size="xl" variant="outline" placeholder="Поиск..." />
                </div>
                <div v-for="item in drafts" class="flex flex-col">
                    <p>{{ item.realeseName }}</p>
                    <UiMyUiButton @click="openDraft(item.id)">
                        Открыть
                    </UiMyUiButton>
                </div>
            </div>
        </div>
    </ProfileLayout>
</template>
<style lang="">
    
</style>