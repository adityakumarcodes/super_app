-- CreateTable
CREATE TABLE "notes_page" (
    "id" SERIAL NOT NULL,
    "userId" TEXT NOT NULL,
    "title" TEXT,
    "description" TEXT,
    "imageUrl" TEXT,
    "editorVersion" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "notes_page_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notes_block" (
    "id" SERIAL NOT NULL,
    "noteId" INTEGER NOT NULL,
    "parentBlockId" INTEGER,
    "blockKey" TEXT,
    "type" TEXT NOT NULL,
    "order" INTEGER NOT NULL DEFAULT 0,
    "data" JSONB NOT NULL,
    "text" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "notes_block_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "notes_page_userId_idx" ON "notes_page"("userId");

-- CreateIndex
CREATE INDEX "notes_block_noteId_idx" ON "notes_block"("noteId");

-- CreateIndex
CREATE INDEX "notes_block_noteId_parentBlockId_idx" ON "notes_block"("noteId", "parentBlockId");

-- CreateIndex
CREATE UNIQUE INDEX "notes_block_noteId_blockKey_key" ON "notes_block"("noteId", "blockKey");

-- AddForeignKey
ALTER TABLE "notes_page" ADD CONSTRAINT "notes_page_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notes_block" ADD CONSTRAINT "notes_block_noteId_fkey" FOREIGN KEY ("noteId") REFERENCES "notes_page"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notes_block" ADD CONSTRAINT "notes_block_parentBlockId_fkey" FOREIGN KEY ("parentBlockId") REFERENCES "notes_block"("id") ON DELETE CASCADE ON UPDATE CASCADE;
