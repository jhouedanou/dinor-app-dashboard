<div class="flex flex-wrap gap-1">
    @if($getRecord()->featured_image)
        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
            Featured
        </span>
    @endif
    
    @if($getRecord()->poster_image)
        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800">
            Poster
        </span>
    @endif
    
    @if($getRecord()->banner_image)
        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-purple-100 text-purple-800">
            Banner
        </span>
    @endif
    
    @if($getRecord()->gallery_images && count($getRecord()->gallery_images) > 0)
        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-yellow-100 text-yellow-800">
            Gallery ({{ count($getRecord()->gallery_images) }})
        </span>
    @endif
    
    @if($getRecord()->getMedia('featured_images')->count() > 0)
        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-indigo-100 text-indigo-800">
            Spatie ({{ $getRecord()->getMedia('featured_images')->count() }})
        </span>
    @endif
    
    @if(!$getRecord()->featured_image && !$getRecord()->poster_image && !$getRecord()->banner_image && 
        (!$getRecord()->gallery_images || count($getRecord()->gallery_images) == 0) &&
        $getRecord()->getMedia('featured_images')->count() == 0)
        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-800">
            Thumbnail uniquement
        </span>
    @endif
</div>