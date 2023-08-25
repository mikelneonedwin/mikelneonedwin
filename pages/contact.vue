<template>
    <div class="w-full">
        <h1 class="title">Contact Me</h1>
        <div class="flex flex-col gap-4 items-center justify-center w-full">
            <h2 class="text-center text-3xl text-[--theme] font-bold">Got Any Questions?</h2>
            <p class="font-bold">I'M AT YOUR SERVICE</p>
            <div class="grid lg:grid-cols-4 sm:grid-cols-1 w-full gap-6 mt-8">
                <div class="cardx">
                    <i class="material-icons">phone</i>
                    <h3>Call</h3>
                    <p>+234 807 6488 738</p>
                </div>
                <div class="cardx">
                    <i class="material-icons">gps_fixed</i>
                    <h3>Address</h3>
                    <p>2b Akwa Ekpene Close, Uyo</p>
                </div>
                <div class="cardx">
                    <i class="material-icons">mail</i>
                    <h3>Email</h3>
                    <p><a href="maiilto:mynameiswinneredwin@gmail.com">mynameiswinneredwin@gmail.com</a></p>
                </div>
                <div class="cardx">
                    <i class="material-icons">public</i>
                    <h3>Website</h3>
                    <p>
                        <a href="https://mikelneonedwin.vercel.app">https://mikelneonedwin.vercel.app</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</template>

<style>
@tailwind components;

@layer components {
    .cardx {
        @apply rounded-lg p-6 flex items-center justify-center flex-col gap-2;
    }
}
.cardx i {
    @apply text-[--theme] mb-3 text-7xl font-bold;
}
.cardx h3 {
    @apply font-bold text-2xl;
}
.cardx p {
    @apply text-center;
}
nav+div {
    @apply sm:w-full;
}
</style>