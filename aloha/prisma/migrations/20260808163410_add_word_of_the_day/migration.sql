-- CreateTable
CREATE TABLE "word_of_the_day" (
    "id" INTEGER NOT NULL,
    "word" TEXT NOT NULL,
    "meaning" TEXT NOT NULL,

    CONSTRAINT "word_of_the_day_pkey" PRIMARY KEY ("id")
);
