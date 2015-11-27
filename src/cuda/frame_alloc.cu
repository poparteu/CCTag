#include <cuda_runtime.h>
#include "debug_macros.hpp"

#include "frame.h"

namespace popart
{

using namespace std;

__host__
void Frame::allocRequiredMem( const cctag::Parameters& params )
{
    _meta.toDevice( Ring_counter_max, EDGE_LINKING_MAX_ARCS, _stream );

    void* ptr;
    const size_t w = getWidth();
    const size_t h = getHeight();
    size_t p;

    POP_CUDA_MALLOC_PITCH( &ptr, &p, w*sizeof(float), h );
    assert( p % _d_smooth.elemSize() == 0 );
    _d_smooth.data = (float*)ptr;
    _d_smooth.step = p;
    _d_smooth.cols = w;
    _d_smooth.rows = h;

    POP_CUDA_MALLOC_PITCH( &ptr, &p, w*sizeof(int16_t), h );
    assert( p % _d_dx.elemSize() == 0 );
    _d_dx.data = (int16_t*)ptr;
    _d_dx.step = p;
    _d_dx.cols = w;
    _d_dx.rows = h;

    POP_CUDA_MALLOC_PITCH( &ptr, &p, w*sizeof(int16_t), h );
    assert( p % _d_dy.elemSize() == 0 );
    _d_dy.data = (int16_t*)ptr;
    _d_dy.step = p;
    _d_dy.cols = w;
    _d_dy.rows = h;

    POP_CUDA_MALLOC_PITCH( &ptr, &p, w*sizeof(float), h );
    assert( p % _d_intermediate.elemSize() == 0 );
    _d_intermediate.data = (float*)ptr;
    _d_intermediate.step = p;
    _d_intermediate.cols = w;
    _d_intermediate.rows = h;

    POP_CUDA_MALLOC_PITCH( &ptr, &p, w*sizeof(uint32_t), h );
    assert( p % _d_mag.elemSize() == 0 );
    _d_mag.data = (uint32_t*)ptr;
    _d_mag.step = p;
    _d_mag.cols = w;
    _d_mag.rows = h;

    POP_CUDA_MALLOC_PITCH( &ptr, &p, w*sizeof(unsigned char), h );
    assert( p % _d_map.elemSize() == 0 );
    _d_map.data = (unsigned char*)ptr;
    _d_map.step = p;
    _d_map.cols = w;
    _d_map.rows = h;

    POP_CUDA_MALLOC_PITCH( &ptr, &p, w*sizeof(unsigned char), h );
    assert( p % _d_hyst_edges.elemSize() == 0 );
    _d_hyst_edges.data = (unsigned char*)ptr;
    _d_hyst_edges.step = p;
    _d_hyst_edges.cols = w;
    _d_hyst_edges.rows = h;

    POP_CUDA_MALLOC_PITCH( &ptr, &p, w*sizeof(unsigned char), h );
    assert( p % _d_edges.elemSize() == 0 );
    _d_edges.data = (unsigned char*)ptr;
    _d_edges.step = p;
    _d_edges.cols = w;
    _d_edges.rows = h;

    POP_CUDA_MALLOC_PITCH( &ptr, &p, EDGE_LINKING_MAX_EDGE_LENGTH*sizeof(cv::cuda::PtrStepInt2_base_t), EDGE_LINKING_MAX_ARCS );
    assert( p % _d_ring_output.elemSize() == 0 );
    _d_ring_output.data = (cv::cuda::PtrStepInt2_base_t*)ptr;
    _d_ring_output.step = p;
    _d_ring_output.cols = EDGE_LINKING_MAX_EDGE_LENGTH;
    _d_ring_output.rows = EDGE_LINKING_MAX_ARCS;

    POP_CUDA_MALLOC_HOST( &ptr, w * h * sizeof(uint8_t) );
    _h_plane.data = (uint8_t*)ptr;
    _h_plane.step = w * sizeof(uint8_t);
    _h_plane.cols = w;
    _h_plane.rows = h;

    POP_CUDA_MALLOC_HOST( &ptr, w * h * sizeof(int16_t) );
    _h_dx.data = (int16_t*)ptr;
    _h_dx.step = w * sizeof(int16_t);
    _h_dx.cols = w;
    _h_dx.rows = h;

    POP_CUDA_MALLOC_HOST( &ptr, w * h * sizeof(int16_t) );
    _h_dy.data = (int16_t*)ptr;
    _h_dy.step = w * sizeof(int16_t);
    _h_dy.cols = w;
    _h_dy.rows = h;

    POP_CUDA_MALLOC_HOST( &ptr, w * h * sizeof(int32_t) );
    _h_mag.data = (uint32_t*)ptr;
    _h_mag.step = w * sizeof(uint32_t);
    _h_mag.cols = w;
    _h_mag.rows = h;

    POP_CUDA_MALLOC_HOST( &ptr, w * h * sizeof(uint8_t) );
    _h_edges.data = (uint8_t*)ptr;
    _h_edges.step = w * sizeof(uint8_t);
    _h_edges.cols = w;
    _h_edges.rows = h;

    POP_CUDA_MALLOC_HOST( &ptr, _d_intermediate.rows * _d_intermediate.step );
    _h_intermediate.data = (float*)ptr;
    _h_intermediate.step = _d_intermediate.step;
    _h_intermediate.cols = _d_intermediate.cols;
    _h_intermediate.rows = _d_intermediate.rows;

#ifndef EDGE_LINKING_HOST_SIDE
    _h_ring_output.data = new cv::cuda::PtrStepInt2_base_t[EDGE_LINKING_MAX_ARCS*EDGE_LINKING_MAX_EDGE_LENGTH];
    // POP_CUDA_MALLOC_HOST( &ptr, EDGE_LINKING_MAX_ARCS*EDGE_LINKING_MAX_EDGE_LENGTH*sizeof(cv::cuda::PtrStepInt2_base_t) );
    // _h_ring_output.data = (cv::cuda::PtrStepInt2_base_t*)ptr;
    _h_ring_output.step = EDGE_LINKING_MAX_EDGE_LENGTH*sizeof(cv::cuda::PtrStepInt2_base_t);
    _h_ring_output.cols = EDGE_LINKING_MAX_EDGE_LENGTH;
    _h_ring_output.rows = EDGE_LINKING_MAX_ARCS;
#endif // EDGE_LINKING_HOST_SIDE

#ifdef DEBUG_WRITE_MAP_AS_PGM
    POP_CUDA_MALLOC_HOST( &ptr, w * h * sizeof(unsigned char) );
    _h_debug_map = (unsigned char*)ptr;
#endif // DEBUG_WRITE_MAP_AS_PGM

    _vote._all_edgecoords.alloc( EDGE_POINT_MAX, EdgeListBoth );
    _voters              .alloc( EDGE_POINT_MAX, EdgeListBoth );
    _vote._seed_indices  .alloc( EDGE_POINT_MAX, EdgeListBoth );
    _vote._seed_indices_2.alloc( EDGE_POINT_MAX, EdgeListDevOnly );

    POP_CUDA_MALLOC_PITCH( &ptr, &p, w*sizeof(int32_t), h );
    assert( p % _vote._d_edgepoint_index_table.elemSize() == 0 );
    _vote._d_edgepoint_index_table.data = (int32_t*)ptr;
    _vote._d_edgepoint_index_table.step = p;
    _vote._d_edgepoint_index_table.cols = w;
    _vote._d_edgepoint_index_table.rows = h;
}

__host__
void Frame::initRequiredMem( )
{
    POP_CUDA_MEMSET_ASYNC( _d_smooth.data,
                           0,
                           _d_smooth.step * _d_smooth.rows,
                           _stream );

    POP_CUDA_MEMSET_ASYNC( _d_intermediate.data,
                           0,
                           _d_intermediate.step * _d_intermediate.rows,
                           _stream );

    POP_CUDA_MEMSET_ASYNC( _d_mag.data,
                           0,
                           _d_mag.step * _d_mag.rows,
                           _stream );

    POP_CUDA_MEMSET_ASYNC( _d_map.data,
                           0,
                           _d_map.step * _d_map.rows,
                           _stream );

    POP_CUDA_MEMSET_ASYNC( _d_dx.data,
                           0,
                           _d_dx.step * _d_dx.rows,
                           _stream );

    POP_CUDA_MEMSET_ASYNC( _d_dy.data,
                           0,
                           _d_dy.step * _d_dy.rows,
                           _stream );

    POP_CUDA_MEMSET_ASYNC( _d_edges.data,
                           0,
                           _d_edges.step * _d_edges.rows,
                           _stream );

    _vote._all_edgecoords.init( _stream );
    _voters              .init( _stream );
    _vote._seed_indices  .init( _stream );
    _vote._seed_indices_2.init( _stream );

    POP_CUDA_MEMSET_ASYNC( _vote._d_edgepoint_index_table.data,
                           0,
                           _vote._d_edgepoint_index_table.step * _vote._d_edgepoint_index_table.rows,
                           _stream );
}

void Frame::releaseRequiredMem( )
{
    POP_CUDA_FREE( _d_plane.data );

    // allocated in allocRequiredMem
    POP_CUDA_FREE( _d_smooth.data );
    POP_CUDA_FREE( _d_dx.data );
    POP_CUDA_FREE( _d_dy.data );
    POP_CUDA_FREE( _d_intermediate.data );
    POP_CUDA_FREE( _d_mag.data );
    POP_CUDA_FREE( _d_map.data );
    POP_CUDA_FREE( _d_hyst_edges.data );
    POP_CUDA_FREE( _d_edges.data );
    POP_CUDA_FREE( _d_ring_output.data );

    cudaFreeHost( _h_plane.data );
    cudaFreeHost( _h_dx.data );
    cudaFreeHost( _h_dy.data );
    cudaFreeHost( _h_mag.data );
    cudaFreeHost( _h_edges.data );
    cudaFreeHost( _h_intermediate.data );
#ifndef EDGE_LINKING_HOST_SIDE
    delete [] _h_ring_output.data;
#endif

#ifdef DEBUG_WRITE_MAP_AS_PGM
    cudaFreeHost( _h_debug_map );
#endif // DEBUG_WRITE_MAP_AS_PGM

    _vote._all_edgecoords.release();
    _voters              .release();
    _vote._seed_indices  .release();
    _vote._seed_indices_2.release();
    POP_CUDA_FREE( _vote._d_edgepoint_index_table.data );
}

}; // namespace popart

